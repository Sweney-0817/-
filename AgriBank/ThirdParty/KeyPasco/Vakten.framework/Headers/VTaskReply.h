/*! Used to confirm or cancel a signing of a task */
typedef NS_ENUM(NSUInteger, VTaskReply) {
    /*! Used for confirming a task. */
    VTaskReplySign = 1,
    /*! Used for denying a task. */
    VTaskReplyCancel = 2
};

enum VTaskPKISign
{
    VTaskPKISignSign = 1,
    VTaskPKISignCancel = 2
};
typedef enum VTaskPKISign VTaskPKISign;
